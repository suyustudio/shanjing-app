.class public final Ll1/a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ls0/g$b;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Ll1/a$a;
    }
.end annotation


# static fields
.field public static final f:Ll1/a$a;


# instance fields
.field public final d:Ljava/lang/Throwable;

.field private final e:Ls0/g$c;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ls0/g$c<",
            "*>;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Ll1/a$a;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Ll1/a$a;-><init>(Lkotlin/jvm/internal/e;)V

    sput-object v0, Ll1/a;->f:Ll1/a$a;

    return-void
.end method

.method public constructor <init>(Ljava/lang/Throwable;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Ll1/a;->d:Ljava/lang/Throwable;

    sget-object p1, Ll1/a;->f:Ll1/a$a;

    iput-object p1, p0, Ll1/a;->e:Ls0/g$c;

    return-void
.end method


# virtual methods
.method public fold(Ljava/lang/Object;La1/p;)Ljava/lang/Object;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<R:",
            "Ljava/lang/Object;",
            ">(TR;",
            "La1/p<",
            "-TR;-",
            "Ls0/g$b;",
            "+TR;>;)TR;"
        }
    .end annotation

    invoke-static {p0, p1, p2}, Ls0/g$b$a;->a(Ls0/g$b;Ljava/lang/Object;La1/p;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public get(Ls0/g$c;)Ls0/g$b;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<E::",
            "Ls0/g$b;",
            ">(",
            "Ls0/g$c<",
            "TE;>;)TE;"
        }
    .end annotation

    invoke-static {p0, p1}, Ls0/g$b$a;->b(Ls0/g$b;Ls0/g$c;)Ls0/g$b;

    move-result-object p1

    return-object p1
.end method

.method public getKey()Ls0/g$c;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ls0/g$c<",
            "*>;"
        }
    .end annotation

    iget-object v0, p0, Ll1/a;->e:Ls0/g$c;

    return-object v0
.end method

.method public minusKey(Ls0/g$c;)Ls0/g;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/g$c<",
            "*>;)",
            "Ls0/g;"
        }
    .end annotation

    invoke-static {p0, p1}, Ls0/g$b$a;->c(Ls0/g$b;Ls0/g$c;)Ls0/g;

    move-result-object p1

    return-object p1
.end method

.method public plus(Ls0/g;)Ls0/g;
    .locals 0

    invoke-static {p0, p1}, Ls0/g$b$a;->d(Ls0/g$b;Ls0/g;)Ls0/g;

    move-result-object p1

    return-object p1
.end method
