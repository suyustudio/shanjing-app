.class final Lr0/b$d;
.super Lr0/b;
.source "SourceFile"

# interfaces
.implements Ljava/util/RandomAccess;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lr0/b;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "d"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "<E:",
        "Ljava/lang/Object;",
        ">",
        "Lr0/b<",
        "TE;>;",
        "Ljava/util/RandomAccess;"
    }
.end annotation


# instance fields
.field private final e:Lr0/b;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lr0/b<",
            "TE;>;"
        }
    .end annotation
.end field

.field private final f:I

.field private g:I


# direct methods
.method public constructor <init>(Lr0/b;II)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lr0/b<",
            "+TE;>;II)V"
        }
    .end annotation

    const-string v0, "list"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0}, Lr0/b;-><init>()V

    iput-object p1, p0, Lr0/b$d;->e:Lr0/b;

    iput p2, p0, Lr0/b$d;->f:I

    sget-object v0, Lr0/b;->d:Lr0/b$a;

    invoke-virtual {p1}, Lr0/a;->size()I

    move-result p1

    invoke-virtual {v0, p2, p3, p1}, Lr0/b$a;->c(III)V

    sub-int/2addr p3, p2

    iput p3, p0, Lr0/b$d;->g:I

    return-void
.end method


# virtual methods
.method public a()I
    .locals 1

    iget v0, p0, Lr0/b$d;->g:I

    return v0
.end method

.method public get(I)Ljava/lang/Object;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I)TE;"
        }
    .end annotation

    sget-object v0, Lr0/b;->d:Lr0/b$a;

    iget v1, p0, Lr0/b$d;->g:I

    invoke-virtual {v0, p1, v1}, Lr0/b$a;->a(II)V

    iget-object v0, p0, Lr0/b$d;->e:Lr0/b;

    iget v1, p0, Lr0/b$d;->f:I

    add-int/2addr v1, p1

    invoke-virtual {v0, v1}, Lr0/b;->get(I)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method
