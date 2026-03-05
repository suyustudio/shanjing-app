.class public final Lh1/f2;
.super Ls0/a;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lh1/f2$a;
    }
.end annotation


# static fields
.field public static final e:Lh1/f2$a;


# instance fields
.field public d:Z


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lh1/f2$a;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lh1/f2$a;-><init>(Lkotlin/jvm/internal/e;)V

    sput-object v0, Lh1/f2;->e:Lh1/f2$a;

    return-void
.end method

.method public constructor <init>()V
    .locals 1

    sget-object v0, Lh1/f2;->e:Lh1/f2$a;

    invoke-direct {p0, v0}, Ls0/a;-><init>(Ls0/g$c;)V

    return-void
.end method
