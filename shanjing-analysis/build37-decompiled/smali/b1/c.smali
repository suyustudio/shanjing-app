.class public abstract Lb1/c;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lb1/c$a;
    }
.end annotation


# static fields
.field public static final d:Lb1/c$a;

.field private static final e:Lb1/c;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lb1/c$a;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lb1/c$a;-><init>(Lkotlin/jvm/internal/e;)V

    sput-object v0, Lb1/c;->d:Lb1/c$a;

    sget-object v0, Lv0/b;->a:Lv0/a;

    invoke-virtual {v0}, Lv0/a;->b()Lb1/c;

    move-result-object v0

    sput-object v0, Lb1/c;->e:Lb1/c;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static final synthetic a()Lb1/c;
    .locals 1

    sget-object v0, Lb1/c;->e:Lb1/c;

    return-object v0
.end method


# virtual methods
.method public abstract b()I
.end method
